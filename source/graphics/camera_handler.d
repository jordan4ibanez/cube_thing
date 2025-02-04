module graphics.camera_handler;

import raylib;

static final const class CameraHandler {
static:
private:

    Camera2D* camera;

    //* BEGIN PUBLIC API.

    public void initialize() {
        camera = new Camera2D();
    }

    public void terminate() {
        camera = null;
    }

    //* BEGIN INTERNAL API.

}
