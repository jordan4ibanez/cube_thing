module graphics.camera_handler;

import game.player;
import raylib;
import std.stdio;
import utility.window;

static final const class CameraHandler {
static:
private:

    Camera2D* camera;

    //* BEGIN PUBLIC API.

    public void initialize() {
        camera = new Camera2D();
        camera.rotation = 0;
        camera.zoom = 250.0;
        camera.target = Vector2(0, 0);
    }

    public void terminate() {
        camera = null;
    }

    public void begin() {
        BeginMode2D(*camera);
    }

    public void end() {
        EndMode2D();
    }

    public void setTarget(Vector2 position) {
        camera.target = position;
    }

    public float getZoom() {
        return camera.zoom;
    }

    public void setZoom(float zoom) {
        camera.zoom = zoom;
    }

    public void centerToPlayer() {
        Vector2 playerPosition = Player.getPosition();
        Vector2 offset = Player.getSize();
        offset.x = 0;
        //? this will move it to the center of the collisionbox.
        // offset.y *= -0.5;
        offset.y = 0;

        Vector2 playerCenter = Vector2Add(playerPosition, offset);

        camera.target = playerCenter;
    }

    public void __update() {
        camera.offset = Vector2Multiply(Window.getSize(), Vector2(0.5, 0.5));
    }

    //* BEGIN INTERNAL API.

}
