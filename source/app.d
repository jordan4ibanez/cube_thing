import std.stdio;

import graphics.camera_handler;
import graphics.font_handler;
import raylib;
import utility.window;

void main() {

	scope (exit) {
		// FontHandler.terminate();
		// ShaderHandler.terminate();
		// TextureHandler.terminate();
		// ModelHandler.terminate();
		Window.terminate();
		CameraHandler.terminate();
	}

	validateRaylibBinding();

	SetTraceLogLevel(TraceLogLevel.LOG_WARNING);

	Window.initialize();

	CameraHandler.initialize();

	while (Window.shouldStayOpen()) {
		BeginDrawing();

		//! Note: DrawTexture and DrawTexturePro are batched as long as you use the same texture.

		ClearBackground(Colors.GRAY);

		EndDrawing();
	}
}
