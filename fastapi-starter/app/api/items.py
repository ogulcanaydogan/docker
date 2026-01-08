"""Example items API endpoints."""

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field

router = APIRouter()


# In-memory storage for demo
_items_db: dict[int, dict] = {}
_counter = 0


class ItemCreate(BaseModel):
    """Schema for creating an item."""

    name: str = Field(..., min_length=1, max_length=100, examples=["My Item"])
    description: str | None = Field(None, max_length=500)
    price: float = Field(..., gt=0, examples=[29.99])
    is_active: bool = Field(default=True)


class ItemUpdate(BaseModel):
    """Schema for updating an item."""

    name: str | None = Field(None, min_length=1, max_length=100)
    description: str | None = Field(None, max_length=500)
    price: float | None = Field(None, gt=0)
    is_active: bool | None = None


class ItemResponse(BaseModel):
    """Schema for item response."""

    id: int
    name: str
    description: str | None
    price: float
    is_active: bool


class PaginatedResponse(BaseModel):
    """Schema for paginated response."""

    items: list[ItemResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


@router.get("/items", response_model=PaginatedResponse)
async def list_items(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(10, ge=1, le=100, description="Items per page"),
    active_only: bool = Query(False, description="Filter active items only"),
):
    """List all items with pagination."""
    items = list(_items_db.values())

    if active_only:
        items = [i for i in items if i["is_active"]]

    total = len(items)
    total_pages = (total + page_size - 1) // page_size

    start = (page - 1) * page_size
    end = start + page_size
    paginated_items = items[start:end]

    return {
        "items": paginated_items,
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": total_pages,
    }


@router.post("/items", response_model=ItemResponse, status_code=201)
async def create_item(item: ItemCreate):
    """Create a new item."""
    global _counter
    _counter += 1

    new_item = {
        "id": _counter,
        "name": item.name,
        "description": item.description,
        "price": item.price,
        "is_active": item.is_active,
    }
    _items_db[_counter] = new_item

    return new_item


@router.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int):
    """Get a specific item by ID."""
    if item_id not in _items_db:
        raise HTTPException(status_code=404, detail="Item not found")

    return _items_db[item_id]


@router.patch("/items/{item_id}", response_model=ItemResponse)
async def update_item(item_id: int, item: ItemUpdate):
    """Update an existing item."""
    if item_id not in _items_db:
        raise HTTPException(status_code=404, detail="Item not found")

    stored_item = _items_db[item_id]
    update_data = item.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        stored_item[field] = value

    return stored_item


@router.delete("/items/{item_id}", status_code=204)
async def delete_item(item_id: int):
    """Delete an item."""
    if item_id not in _items_db:
        raise HTTPException(status_code=404, detail="Item not found")

    del _items_db[item_id]
