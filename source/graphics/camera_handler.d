module graphics.camera_handler;

import raylib;

static final const class CameraHandler {
static:
private:

    Camera2D* camera;

    public void initialize() {
        camera = new Camera2D();
    }

}
