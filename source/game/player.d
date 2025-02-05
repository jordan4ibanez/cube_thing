module game.player;

import raylib;

static final const class Player {
static:
private:

    Vector2 size = Vector2(0.6, 1.8);
    Vector2 position = Vector2(0, 0);

    //* BEGIN PUBLIC API.

    public Vector2 getSize() {
        return size;
    }

    public Vector2 getPosition() {
        return position;
    }

    public void draw() {
        DrawRectangleV(position, size, Colors.WHITE);
    }

    //* BEGIN INTERNAL API.

}
