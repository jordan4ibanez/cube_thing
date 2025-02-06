module utility.drawing_functions;

import raylib;

/// This takes the game coordinates and shifts it to be drawn by raylib for a rectangle.
Vector2 centerCollisionboxBottom(Vector2 position, Vector2 size) {
    Vector2 newPosition = position;
    newPosition.x -= size.x * 0.5;
    newPosition.y += size.y;
    return newPosition;
}
