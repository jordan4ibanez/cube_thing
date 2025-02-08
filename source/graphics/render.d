module graphics.render;

import raylib;

static final const class Render {
static:
private:

public: //* BEGIN PUBLIC API.

    void rectangle(Vector2 position, Vector2 size, Color color) {
        DrawRectangleV(invertPosition(position), size, color);
    }

    void rectangleLines(Vector2 position, Vector2 size, Color color, double thickness = 0.01) {
        Vector2 invertedPosition = invertPosition(position);
        Rectangle rect = Rectangle(invertedPosition.x, invertedPosition.y, size.x, size.y);
        DrawRectangleLinesEx(rect, thickness, color);
    }

    void circle(Vector2 center, double radius, Color color) {
        Vector2 invertedPosition = invertPosition(center);
        DrawCircleV(invertedPosition, radius, color);
    }

private: //* BEGIN INTERNAL API.

    Vector2 invertPosition(Vector2 position) {
        return Vector2(position.x, -position.y);
    }

}
