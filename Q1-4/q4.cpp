// Q4 - Assume all method calls work fine. Fix the memory leak issue in below method
// (C++)
// There is a memory leak issue when a player object is created by the function and not freed before the function returns
// The player object isn't always created (sometimes it already exists and passed in), so we will need to only free our memory if the object is created
// My solution will create a new boolean to track if a player object has been created; it will be set to true when we allocate memory for the object
// before any branch of the function returns, we will delete the allocated player memory if it has been allocated
// player is a pointer, so we can use delete on it directly to free up the allocated memory

void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
    Player* player = g_game.getPlayerByName(recipient);
    bool allocPlayer = false; //Track if a player was created inside the function

    if (!player) {
        player = new Player(nullptr);
        if (!IOLoginData::loadPlayerByName(player, recipient)) {
            delete player; //free player
            return;
        }
        allocPlayer = true; //we have allocated memory
    }

    Item* item = Item::CreateItem(itemId);
    if (!item) {
        if(allocPlayer){ //free memory if we allocated it in the function
            delete player;
        }
        return;
    }

    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

    if (player->isOffline()) {
        IOLoginData::savePlayer(player);
    }

    if(allocPlayer){ //free memory if we allocated it in the function
        delete player;
    }
}
