module graphics.camera_handler;

import raylib;
import utility.window;

static final const class CameraHandler {
static:
private:

    Camera2D* camera;

    //* BEGIN PUBLIC API.

    public void initialize() {
        camera = new Camera2D();
        camera.rotation = 0;
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

    public void __update() {
        camera.offset = Vector2Multiply(Window.getSize(), Vector2(0.5, 0.5));
    }

    //* BEGIN INTERNAL API.

}
