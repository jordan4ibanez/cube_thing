module graphics.camera_handler;

import game.player;
import raylib;
import std.stdio;
import utility.window;

static final const class CameraHandler {
static:
private:

    Camera2D* camera;

public: //* BEGIN PUBLIC API.

    void initialize() {
        camera = new Camera2D();
        camera.rotation = 0;
        camera.zoom = 100.0;
        camera.target = Vector2(0, 0);
    }

    void terminate() {
        camera = null;
    }

    void begin() {
        Matrix4 matOrigin = MatrixTranslate(-camera.target.x, camera.target.y, 0.0);
        Matrix4 matRotation = MatrixRotate(Vector3(0, 0, 1), camera.rotation * DEG2RAD);
        Matrix4 matScale = MatrixScale(camera.zoom, camera.zoom, 1.0);
        Matrix4 matTranslation = MatrixTranslate(camera.offset.x, camera.offset.y, 0.0);
        Matrix4 output = MatrixMultiply(MatrixMultiply(matOrigin, MatrixMultiply(matScale, matRotation)),
            matTranslation);

        BeginMode2D(*camera);
        rlSetMatrixModelview(output);
        // rlDisableBackfaceCulling();
    }

    void end() {
        EndMode2D();
    }

    void setTarget(Vector2 position) {
        camera.target = position;
    }

    float getZoom() {
        return camera.zoom;
    }

    void setZoom(float zoom) {
        camera.zoom = zoom;
    }

    void centerToPlayer() {
        Vector2 playerPosition = Player.getPosition();
        Vector2 offset = Player.getSize();
        offset.x = 0;
        //? this will move it to the center of the collisionbox.
        // offset.y *= -0.5;
        offset.y = 0;

        Vector2 playerCenter = Vector2Add(playerPosition, offset);

        camera.target = playerCenter;
    }

    void __update() {
        camera.offset = Vector2Multiply(Window.getSize(), Vector2(0.5, 0.5));
    }

private: //* BEGIN INTERNAL API.

}
