module graphics.render;

import raylib;

static final const class Render {
static:
private:

public: //* BEGIN PUBLIC API.

    void rectangle(Vector2 position, Vector2 rotation, Color color) {
        DrawRectangleV(invertPosition(position), rotation, color);
    }

private: //* BEGIN INTERNAL API.

    Vector2 invertPosition(Vector2 position) {
        return Vector2(position.x, -position.y);
    }

}
