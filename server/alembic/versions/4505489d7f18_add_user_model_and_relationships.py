"""Add user model and relationships

Revision ID: 4505489d7f18
Revises: c32d9f5156e5
Create Date: 2026-02-27 12:29:00.918031

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import uuid

# revision identifiers, used by Alembic.
revision: str = '4505489d7f18'
down_revision: Union[str, Sequence[str], None] = 'c32d9f5156e5'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    # 1. Create users table
    op.create_table(
        'users',
        sa.Column('id', sa.String(), nullable=False),
        sa.Column('email', sa.String(), nullable=False),
        sa.Column('hashed_password', sa.String(), nullable=False),
        sa.Column('full_name', sa.String(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)
    op.create_index(op.f('ix_users_id'), 'users', ['id'], unique=False)

    # 2. Update daily_reports table
    with op.batch_alter_table('daily_reports', schema=None) as batch_op:
        batch_op.add_column(sa.Column('user_id', sa.String(), nullable=False))
        batch_op.create_foreign_key('fk_report_user', 'users', ['user_id'], ['id'])

    # 3. Update records table
    with op.batch_alter_table('records', schema=None) as batch_op:
        batch_op.add_column(sa.Column('user_id', sa.String(), nullable=False))
        batch_op.create_foreign_key('fk_record_user', 'users', ['user_id'], ['id'])

def downgrade() -> None:
    with op.batch_alter_table('records', schema=None) as batch_op:
        batch_op.drop_constraint('fk_record_user', type_='foreignkey')
        batch_op.drop_column('user_id')

    with op.batch_alter_table('daily_reports', schema=None) as batch_op:
        batch_op.drop_constraint('fk_report_user', type_='foreignkey')
        batch_op.drop_column('user_id')

    op.drop_index(op.f('ix_users_id'), table_name='users')
    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_table('users')
