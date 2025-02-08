module game.block_database;

import graphics.texture_handler;
import std.string;
import std.stdio;
import std.conv;

class BlockDefinition {
    string name = null;
    string modName = null;
    string texture = null;
    int id = -1;
}

struct BlockResult {
    BlockDefinition definition = null;
    bool exists = false;
}

static final const class BlockDatabase {
static:
private:

    // Faster access based on ID or name.
    BlockDefinition[string] nameDatabase;
    BlockDefinition[int] idDatabase;

    int currentID = 0;

public: //* BEGIN PUBLIC API.

    void registerBlock(BlockDefinition newBlock) {

        if (newBlock.name is null) {
            throw new Error("Name for block is null.");
        }

        if (newBlock.name.toLower() == "air") {
            throw new Error("Block air is reserved by engine.");
        }

        if (newBlock.name in nameDatabase) {
            throw new Error("Trying to overwrite block " ~ newBlock.name);
        }

        if (newBlock.modName is null) {
            throw new Error("Mod name for block is null.");
        }

        if (newBlock.texture is null) {
            throw new Error("Texture for block is null.");
        }

        if (!TextureHandler.hasTexture(newBlock.texture)) {
            throw new Error("Texture for block does not exist.");
        }

        nameDatabase[newBlock.name] = newBlock;
    }

    BlockResult getBlockByID(int id) {
        if (id !in idDatabase) {
            return BlockResult();
        }

        return BlockResult(idDatabase[id], true);
    }

    BlockResult getBlockByName(string name) {
        if (name !in nameDatabase) {
            return BlockResult();
        }
        return BlockResult(nameDatabase[name], true);
    }

    void finalize() {
        makeAir();

    }

private: //* BEGIN INTERNAL API.

    void makeAir() {
        BlockDefinition air = new BlockDefinition();
        air.name = "air";
        air.modName = "engine";
        air.texture = "air.png";
        // todo: do the match thing below when mongoDB is added in.
        air.id = nextID();

        nameDatabase[air.name] = air;
        idDatabase[air.id] = air;
    }

    void debugWrite(BlockDefinition definition) {
        writeln("Block " ~ definition.name ~ " at ID " ~ to!string(definition.id));
    }

    // todo: make this pull the standard IDs into an associative array from the mongoDB.
    // todo: mongoDB should store the MAX current ID and restore it.
    // todo: Then, match to it. If it doesn't match, this is a new block.
    // todo: Then you'd call into this. :)
    int nextID() {
        int thisID = currentID;
        currentID++;
        return thisID;
    }

}
