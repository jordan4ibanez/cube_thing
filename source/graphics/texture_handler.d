module graphics.texture_handler;

import raylib;
import std.container;
import std.file;
import std.path;
import std.regex;
import std.stdio;
import std.string;

static final const class TextureHandler {
static:
private:

    Texture2D*[string] database;

public: //* BEGIN PUBLIC API.

    void initialize() {
        foreach (string thisFilePathString; dirEntries("textures", "*.png", SpanMode.depth)) {
            loadTexture(thisFilePathString);
        }
    }

    void drawTexture(string textureName, Vector2 position, Vector2 sourceSize, Vector2 size) {
        if (textureName !in database) {
            throw new Error(
                "[TextureManager]: Texture does not exist. Cannot draw. " ~ textureName);
        }
        Vector2 flippedPosition = Vector2(position.x, -position.y);

        Rectangle source = Rectangle(0, 0, sourceSize.x, sourceSize.y);
        Rectangle dest = Rectangle(flippedPosition.x, flippedPosition.y, size.x, size.y);

        DrawTexturePro(*database[textureName], source, dest, Vector2(0, 0), 0, Colors.WHITE);
    }

    bool hasTexture(string name) {
        if (name in database) {
            return true;
        }
        return false;
    }

    void loadTexture(string location) {

        // Extract the file name from the location.
        string fileName = () {
            string[] items = location.split("/");
            int len = cast(int) items.length;
            if (len <= 1) {
                throw new Error("[TextureManager]: Texture must not be in root directory.");
            }
            string outputFileName = items[len - 1];
            if (!outputFileName.endsWith(".png")) {
                throw new Error("[TextureManager]: Not a .png");
            }
            return outputFileName;
        }();

        if (fileName in database) {
            throw new Error("[TextureManager]: Tried to overwrite [" ~ fileName ~ "]");
        }

        Texture2D* thisTexture = new Texture2D();
        *thisTexture = LoadTexture(toStringz(location));

        if (!IsTextureValid(*thisTexture)) {
            throw new Error("[TextureManager]: Texture [" ~ location ~ "] is invalid.");
        }

        database[fileName] = thisTexture;
    }

    Texture2D* getTexturePointer(string textureName) {
        if (textureName !in database) {
            throw new Error("[TextureManager]: Texture does not exist. " ~ textureName);
        }

        return database[textureName];
    }

    void deleteTexture(string textureName) {
        if (textureName !in database) {
            throw new Error(
                "[TextureManager]: Texture does not exist. Cannot delete. " ~ textureName);
        }

        Texture* thisTexture = database[textureName];
        UnloadTexture(*thisTexture);
        database.remove(textureName);
    }

    void terminate() {
        foreach (textureName, thisTexture; database) {
            UnloadTexture(*thisTexture);
        }

        database.clear();
    }

private: //* BEGIN INTERNAL API.
}
