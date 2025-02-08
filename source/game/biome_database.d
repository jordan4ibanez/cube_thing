module game.biome_database;

class BiomeDefinition {

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

public: //* BEGIN PUBLIC API.

    void registerBiome(BiomeDefinition newBiome) {

        if (newBiome.grassLayer is null) {

        }

        if (newBiome.dirtLayer is null) {

        }

    }

private: //* BEGIN INTERNAL API.

}
