module game.biome_database;

class BiomeDefinition {
    string name = null;

    string grassLayer = null;
    int grassLayerID = -1;
    string dirtLayer = null;
    int dirtLayerID = -1;
    string stoneLayer = null;
    int stoneLayerID = -1;
}

static final const class BlockDatabase {
static:
private:

    // Faster access based on ID or name.
    BiomeDefinition[string] nameDatabase;
    BiomeDefinition[int] idDatabase;

public: //* BEGIN PUBLIC API.

    void registerBiome(BiomeDefinition newBiome) {

        if (newBiome.name is null) {
            throw new Error("Biome is missing a name.");
        }

        if (newBiome.name in nameDatabase) {
            throw new Error("Tried to overwrite biome" ~ newBiome.name);
        }

        if (newBiome.grassLayer is null) {
            throw new Error("Grass layer missing from biome " ~ newBiome.name);
        }

        if (newBiome.dirtLayer is null) {
            throw new Error("Dirt layer missing from biome " ~ newBiome.name);
        }

        if (newBiome.stoneLayer is null) {
            throw new Error("Stone layer missing from biome " ~ newBiome.name);
        }

        nameDatabase[newBiome.name] = newBiome;
    }

    void finalize() {

    }

private: //* BEGIN INTERNAL API.

}
