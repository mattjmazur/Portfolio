"""
Classes 'Player', 'LudoGame', and 'Board', which work together to represent a 
game of ludo.
"""

class Player:
    """
    Represents a player of the Ludo game. Stores data members that represent a players positioning on the
    game board.
    """

    def __init__(self, position):
        """
        :param position: str ('A', 'B', 'C', or 'D')
        """
        self._position = position
        self._start_space = None
        self._end_space = None
        self.determine_spaces()  # initializes 'start_space' and 'end_space' depend on value of 'position'
        self._completed = False  # completed set to True when both tokens reach the finishing square

        # position can be position -1 (home), 0 (ready-to-go), an integer from 1-57. This value represents the relative
        # position of the token with respect to the players starting position
        self._token_p_position = -1
        self._token_q_position = -1

        self._tokens_stacked = False  # when True both tokens move together

    def determine_spaces(self):
        """
        Called by the init function of the Player class and sets the '_start_space' and '_end_space' data-members
        according to the parameter passed during object instantiation
        """
        if self._position == 'A':
            self._start_space = 1
            self._end_space = 50
        elif self._position == 'B':
            self._start_space = 15
            self._end_space = 8
        elif self._position == 'C':
            self._start_space = 29
            self._end_space = 22
        else:
            self._start_space = 43
            self._end_space = 36

    def update_position(self, token, num_steps):
        """
        Checks if token is in the home yard or the home squares, which will alter the
        behavior of the move algorithm.

        Adds num_steps to specified token's position data-member.

        If the player's tokens are stacked, it will also move the player's other token.

        :param token: str ('q' or 'p')
        :param num_steps: int
        """
        if token == 'q':
            if self._token_q_position == -1:
                if num_steps == 6:
                    self._token_q_position = 0
            elif self._token_q_position > 50:
                if self._token_q_position + num_steps == 57:
                    self._token_q_position = 57
                elif self._token_q_position + num_steps > 57:
                    num_spaces_minus = self._token_q_position + num_steps - 57
                    self._token_q_position = 57 - num_spaces_minus
                else:
                    self._token_q_position += num_steps
            else:
                self._token_q_position += num_steps

        elif self._token_p_position == -1:
            if num_steps == 6:
                self._token_p_position = 0
        elif self._token_p_position > 50:
            if self._token_p_position + num_steps == 57:
                self._token_p_position = 57
            elif self._token_p_position + num_steps > 57:
                num_spaces_minus = self._token_p_position + num_steps - 57
                self._token_p_position = 57 - num_spaces_minus
            else:
                self._token_p_position += num_steps
        else:
            self._token_p_position += num_steps

        # if the player's tokens are stacked, it moves the other token as well
        if self._tokens_stacked and token == 'p':
            self._token_q_position = self._token_p_position
        elif self._tokens_stacked and token == 'q':
            self._token_p_position = self._token_q_position

    def get_completed(self):
        """
        :return: bool
        """
        return self._completed

    def get_token_p_step_count(self):
        """
        :return: int
        """
        return self._token_p_position

    def get_token_q_step_count(self):
        """
        :return: int
        """
        return self._token_q_position

    def get_space_name(self, token_position):
        """
        Takes as a parameter the position (ie relative number of steps) of a token as an int and returns the "absolute"
        name of that position as a string:

        It returns 'H' if the token is at the 'home' position (ie position -1), and 'R' if it is at the
        'ready-to-go' position (ie position 0), or one of the names of the player's home squares if total_steps
        is 51-57. Otherwise, it adds the total_steps to the players starting position and returns this value.

        :param: token_position: int
        :return: str
        """
        if token_position == -1:
            return 'H'
        elif token_position == 0:
            return 'R'
        elif self._position == 'A':
            if token_position == 51:
                return 'A1'
            elif token_position == 52:
                return 'A2'
            elif token_position == 53:
                return 'A3'
            elif token_position == 54:
                return 'A4'
            elif token_position == 55:
                return 'A5'
            elif token_position == 56:
                return 'A6'
            elif token_position == 57:
                return 'E'
            return str(token_position)
        elif self._position == 'B':
            if token_position == 51:
                return 'B1'
            elif token_position == 52:
                return 'B2'
            elif token_position == 53:
                return 'B3'
            elif token_position == 54:
                return 'B4'
            elif token_position == 55:
                return 'B5'
            elif token_position == 56:
                return 'B6'
            elif token_position == 57:
                return 'E'
            elif token_position + 14 < 57:
                return str(token_position + 14)
            return str(token_position + 14 - 56)
        elif self._position == 'C':
            if token_position == 51:
                return 'C1'
            elif token_position == 52:
                return 'C2'
            elif token_position == 53:
                return 'C3'
            elif token_position == 54:
                return 'C4'
            elif token_position == 55:
                return 'C5'
            elif token_position == 56:
                return 'C6'
            elif token_position == 57:
                return 'E'
            elif token_position + 28 < 57:
                return str(token_position + 28)
            return str(token_position + 28 - 56)
        elif self._position == 'D':
            if token_position == 51:
                return 'D1'
            elif token_position == 52:
                return 'D2'
            elif token_position == 53:
                return 'D3'
            elif token_position == 54:
                return 'D4'
            elif token_position == 55:
                return 'D5'
            elif token_position == 56:
                return 'D6'
            elif token_position == 57:
                return 'E'
            elif token_position + 42 < 57:
                return str(token_position + 42)
            return str(token_position + 42 - 56)

    def set_token_p_home(self):
        """
        Called on by the 'check_positions' method of the Board class when this token was hit by another player's
        token. Sets the Player-object's token_p_position to 'H'.
        """
        self._token_p_position = -1

    def set_token_q_home(self):
        """
        Called on by the 'check_positions' method of the Board class when this token was hit by another player's
        token. Sets the Player-object's token_q_position to -1.
        """
        self._token_q_position = -1

    def set_stack_tokens(self, val):
        """
        Called on by the 'check_positions' method of the Board class when this token was hit by another player's
        token. Un-stacks the Player's tokens after they are both in the home yard.
        :param: val: bool
        """
        if self.get_token_q_step_count() == 0:
            return
        self._tokens_stacked = val

    def get_tokens_stacked(self):
        """
        :return: bool
        """
        return self._tokens_stacked

    def get_position(self):
        """
        :return: str
        """
        return self._position


class Board:
    """
    This class holds a list of Player objects representing players of a current game. It is created by the LudoGame
    class method 'play_game' and has methods used by the LudoGame object to run the game.
    """

    def __init__(self, players):
        """
        Takes a list of Player-objects and sets this as the data-member 'players'
        :param players: list
        """
        self._players = players

    def get_players(self):
        """
        :return: list
        """
        return self._players

    def check_positions(self, current_player_turn, current_turn_token_name):
        """
        Checks to see if current_player_turn has completed the game, and checks if the current_player_turn has just
        landed their token on another player's token, in which case it will send the other player's token back to the
        home space. It will also stack the current_player_turn's tokens if their current turn has just stacked their
        tokens. It also will deal with unstacking a player's tokens if needed.

        :param: current_player_turn should be a Player object for the player whose turn it currently is
        :param: current_turn_token_name a string, either 'p' or 'q' depending on what token was just moved
        """
        # set stack_tokens to True if player's tokens are on the same space
        if current_player_turn.get_token_p_step_count() == current_player_turn.get_token_q_step_count():
            current_player_turn.set_stack_tokens(True)

        # if both of the current_players tokens are on space 57, the player has completed the game
        if current_player_turn.get_token_p_step_count() == 57 and current_player_turn.get_token_q_step_count() == 57:
            current_player_turn._completed = True

        # We call get_list_of_token_pos_dict to get dictionaries containing keys of player-objects
        # and values of the current positions of that player's p and q tokens (1 dictionary for each token name)
        token_pos_dict_list = self.get_list_of_token_pos_dict(current_player_turn=current_player_turn)
        token_p_spaces = token_pos_dict_list[0]
        token_q_spaces = token_pos_dict_list[1]

        if current_turn_token_name == 'p':
            current_player_space = current_player_turn.get_space_name(current_player_turn.get_token_p_step_count())
        else:
            current_player_space = current_player_turn.get_space_name(current_player_turn.get_token_q_step_count())

        # now we check if the current_player_space is contained in token_p_spaces or token_q_spaces, if it is
        # we will send the token currently on that space back to the home space, and we also unstack
        # the moved player's tokens if they are currently stacked
        if current_player_space in token_p_spaces.values() and \
                (current_player_space != 'H' and current_player_space != 'R'):
            matched_player = None
            for k in token_p_spaces:
                if token_p_spaces[k] == current_player_space:
                    matched_player = k
            if matched_player.get_tokens_stacked():
                matched_player.set_token_q_home()
                matched_player.set_stack_tokens(False)
            matched_player.set_token_p_home()

        elif current_player_space in token_q_spaces.values() and \
                (current_player_space != 'H' and current_player_space != 'R'):
            matched_player = None
            for k in token_q_spaces:
                if token_q_spaces[k] == current_player_space:
                    matched_player = k
            if matched_player.get_tokens_stacked():
                matched_player.set_token_p_home()
                matched_player.set_stack_tokens(False)
            matched_player.set_token_q_home()

    def get_list_of_token_pos_dict(self, current_player_turn):
        """
        Returns a list of 2 dictionaries. The 0 index of the list will contain a dictionary that contains keys of
        player-objects, and values of current position of that player's p token. The 1 index of the list contains
        keys of player-objects and values of the current position of that player's q token.

        Both dictionaries exclude the token values of the current_player_turn.

        :param: current_player_turn: Player
        :return: list
        """
        return_list = []
        token_q_spaces = {}
        token_p_spaces = {}

        for player in self._players:
            if player is current_player_turn:
                continue
            else:
                token_p_step = player.get_token_p_step_count()
                token_q_step = player.get_token_q_step_count()
                token_p_spaces[player] = str(player.get_space_name(token_p_step))
                token_q_spaces[player] = str(player.get_space_name(token_q_step))
        return_list.append(token_p_spaces)
        return_list.append(token_q_spaces)
        return return_list


class LudoGame:
    """
    Represents the ludo game using the play_game method as the main game engine
    """

    def __init__(self):
        """
        Creates data-members containing a list of players of the game and the board object used to create the
        game. These are updated once the play_game method has been called.
        """
        self._players = None
        self._board = None

    def get_player_by_position(self, player_position):
        """
        Loops through 'players' list and returns the player object with a matching position to 'player_position',
        else return string "Player not found!"
        :param: player_position: str
        :return: Player or str
        """
        for player in self._players:
            if player.get_position() == player_position:
                return player
        return 'Player not found!'

    def move_token(self, player_obj, token_name, num_step):
        """
        Adds the num_steps to 'player_obj's 'token_name' position data-member by calling 'player_obj's method
        'update_position'.

        Also calls the 'check_positions' method on the 'board' data-member to see if any changes to any data-members
        of each 'Player' object in the Board need to be made because of this move.
        :param: player_obj: Player
        :param: token_name: str
        :param: num_step: int
        """
        if player_obj.get_completed():
            return
        player_obj.update_position(token=token_name, num_steps=num_step)
        self._board.check_positions(current_player_turn=player_obj, current_turn_token_name=token_name)

    def play_game(self, players_list, turns_list):
        """
        Loops through each tuple in turns_list. For each tuple the priority rules are used to determine which token is
        moved, then the move_token method of this LudoGame object is called and finally the check_positions method is
        called on the self._board data-member.

        :param: players_list: a list of positions players choose (e.g. ['A', 'B'])
        :param: turns_list: a list of tuples with each tuple a roll for one player (e.g. [('A', 6), ('A', 4), ('C', 5)]
        :return: a list of strings representing the current spaces of all the tokens for each player after all turns
        in turns_list have been played
        """

        # create player objects for each player position in players_list, and then populate player_obj_list and
        # player_obj_dict
        player_obj_list = []
        player_obj_dict = {}

        for player_position in players_list:
            new_player = Player(player_position)
            player_obj_list.append(new_player)
            player_obj_dict[player_position] = new_player

        # create a board object using the player_obj_list
        self._board = Board(player_obj_list)
        self._players = player_obj_list

        for turn in turns_list:

            current_player_obj = player_obj_dict[turn[0]]
            current_turn_val = turn[1]

            # creating a list of the positions of all the current_player_obj opponents' tokens
            token_pos_dict_list = self._board.get_list_of_token_pos_dict(current_player_turn=current_player_obj)
            opponent_token_p_val = token_pos_dict_list[0]
            opponent_token_q_val = token_pos_dict_list[1]

            # marking the possible values of the current_player_obj tokens if the current_turn_val was used
            # on each of them
            token_p_poss_val = current_player_obj.get_token_p_step_count() + current_turn_val
            token_p_poss_pos = current_player_obj.get_space_name(token_position=token_p_poss_val)
            token_q_poss_val = current_player_obj.get_token_q_step_count() + current_turn_val
            token_q_poss_pos = current_player_obj.get_space_name(token_position=token_q_poss_val)

            # if current_turn_val is 6 and the current_turn's player still has a token in the home space, move
            # this token out of the home space, with preference given to token p if both of the player's tokens are
            # in the home spaces

            if current_turn_val == 6 and (current_player_obj.get_token_p_step_count() == -1 or
                                          current_player_obj.get_token_q_step_count() == -1):
                if current_player_obj.get_token_p_step_count() == -1:
                    self.move_token(player_obj=current_player_obj, token_name='p', num_step=current_turn_val)
                else:
                    self.move_token(player_obj=current_player_obj, token_name='q', num_step=current_turn_val)

            # if one of the player's tokens is already in the home squares and the step number is exactly what is
            # needed to reach the end square, this token will be moved
            elif current_player_obj.get_token_q_step_count() + current_turn_val == 57:
                self.move_token(player_obj=current_player_obj, token_name='q', num_step=current_turn_val)
            elif current_player_obj.get_token_p_step_count() + current_turn_val == 57:
                self.move_token(player_obj=current_player_obj, token_name='p', num_step=current_turn_val)

            # if one of the player's token can move and kick out an opponent's token, this token will be moved
            elif token_p_poss_pos in (opponent_token_p_val.values() or opponent_token_p_val.values()):
                self.move_token(player_obj=current_player_obj, token_name='p', num_step=current_turn_val)
            elif token_q_poss_pos in (opponent_token_p_val.values() or opponent_token_q_val.values()):
                self.move_token(player_obj=current_player_obj, token_name='q', num_step=current_turn_val)

            # if none of the above conditions apply to the turn, the player's token that is the furthest away from the
            # finishing square will be moved
            elif (
                    current_player_obj.get_token_p_step_count() > current_player_obj.get_token_q_step_count()) and \
                    current_player_obj.get_token_q_step_count() != -1:
                self.move_token(player_obj=current_player_obj, token_name='q', num_step=current_turn_val)
            else:
                self.move_token(player_obj=current_player_obj, token_name='p', num_step=current_turn_val)

        # a list of strings describing the positions of all the game's players' tokens is created and
        # returned
        str_return_list = []
        for player in player_obj_list:
            str_return_list.append(f'{player.get_space_name(player.get_token_p_step_count())}')
            str_return_list.append(f'{player.get_space_name(player.get_token_q_step_count())}')
        return str_return_list
