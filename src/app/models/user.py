"""User model definition."""

from datetime import datetime
from uuid import UUID, uuid4

from sqlmodel import Field, SQLModel


class UserBase(SQLModel):
    """Shared user fields."""

    email: str = Field(unique=True, index=True, max_length=255)
    username: str = Field(unique=True, index=True, max_length=50)
    is_active: bool = Field(default=True)
    is_verified: bool = Field(default=False)
    role: str = Field(default="user", max_length=20)


class User(UserBase, table=True):
    """User database table."""

    __tablename__ = "users"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    hashed_password: str = Field(max_length=255)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)


class UserCreate(UserBase):
    """Schema for creating a user."""

    password: str = Field(min_length=8, max_length=128)


class UserRead(UserBase):
    """Schema for reading a user (public)."""

    id: UUID
    created_at: datetime


class UserUpdate(SQLModel):
    """Schema for updating a user."""

    email: str | None = None
    username: str | None = None
    password: str | None = Field(default=None, min_length=8, max_length=128)
