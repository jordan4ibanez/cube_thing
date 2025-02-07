module game.block_database;

class BlockDefinition {
    string name = null;
    string modName = null;
    string texture = null;
    int id = 0;
}

static final const class BlockDatabase {
static:
private:

    BlockDefinition[string] databaseName;
    BlockDefinition[int] databaseID;

public: //* BEGIN PUBLIC API.

    void registerBlock(BlockDefinition newBlock) {

        if (newBlock.name is null) {
            throw new Error("Name for block is null.");
        }

        if (newBlock.name in databaseName) {
            throw new Error("Trying to override block " ~ newBlock.name);
        }

        if (newBlock.modName is null) {
            throw new Error("Mod name for block is null.");
        }

        if (newBlock.texture is null) {
            throw new Error("Texture for block is null.");
        }

        if (newBlock.id <= 0) {

        }
    }

private: //* BEGIN INTERNAL API.

}
