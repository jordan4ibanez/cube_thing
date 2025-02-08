module graphics.gui;

import raylib.raylib_types;

static final const class GUI {
static:
private:

    // We standardize the GUI with 1080p.
    immutable Vector2 standardSize = Vector2(1920.0, 1080.0);
    double currentGUIScale = 1.0;

public: //* BEGIN PUBLIC API.

    double getGUIScale() {
        return currentGUIScale;
    }

    void __update(Vector2 newWindowSize) {
        // Find out which GUI scale is smaller so things can be scaled around it.

        Vector2 scales = Vector2(newWindowSize.x / standardSize.x, newWindowSize.y / standardSize.y);

        if (scales.x >= scales.y) {
            currentGUIScale = scales.y;
        } else {
            currentGUIScale = scales.x;
        }
    }

private: //* BEGIN INTERNAL API.
}
