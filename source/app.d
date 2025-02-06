import std.stdio;

import controls.keyboard;
import game.map;
import game.player;
import graphics.camera_handler;
import graphics.font_handler;
import raylib;
import std.conv;
import std.math.traits;
import std.string;
import utility.collision_functions;
import utility.delta;
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

	Map.initialize();

	while (Window.shouldStayOpen()) {

		CameraHandler.centerToPlayer();

		double delta = Delta.getDelta();

		Player.move();

		BeginDrawing();
		{
			//! Note: DrawTexture and DrawTexturePro are batched as long as you use the same texture.

			ClearBackground(Colors.BLACK);

			CameraHandler.begin();
			{
				Map.draw();
				Player.draw();
			}
			CameraHandler.end();

			Vector2 center = Vector2Multiply(Window.getSize(), Vector2(0.5, 0.5));
			DrawCircle(cast(int) center.x, cast(int) center.y, 4, Colors.RED);

			Vector2 playerPos = Player.getPosition();
			DrawText(toStringz("y: " ~ to!string(playerPos.y)), 0, 0, 120, Colors.WHITE);
			DrawText(toStringz("x: " ~ to!string(playerPos.x)), 0, 120, 120, Colors.WHITE);
		}
		EndDrawing();
	}
}
