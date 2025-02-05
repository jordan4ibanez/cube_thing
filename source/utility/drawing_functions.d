module utility.drawing_functions;

import raylib;

/// This takes the game coordinates and shifts it to be drawn by raylib for a rectangle.
Vector2 centerCollisionboxBottom(Vector2 position, Vector2 size) {
    Vector2 offset = Vector2Multiply(size, Vector2(0.5, 1));
    Vector2 rectangleOrigin = Vector2Subtract(position, offset);
    return rectangleOrigin;
}
