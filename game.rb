#!/usr/bin/env ruby

require_relative 'lib/aipicker'
require_relative 'lib/background'
require_relative 'lib/board'
require_relative 'lib/boardlogic'
require_relative 'lib/boundingbox'
require_relative 'lib/cell'
require_relative 'lib/menu'
require_relative 'lib/player'
require 'gosu'

class GameWindow < Gosu::Window
  attr_accessor :state

  SCREEN_WIDTH  = 600
  SCREEN_HEIGHT = 550
  HUMAN = 1
  EASY = 2
  EXPERT = 5

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
    @board       = Board.new(self)
    @background  = Background.new(self)
    @menu        = Menu.new(self, 40, 70, @board)
    @board_logic = BoardLogic.new(self, @board)
    @state       = :menu
    @big_font    = Gosu::Font.new(self, "Futura", SCREEN_HEIGHT / 8)
    @medium_font = Gosu::Font.new(self, "Futura", SCREEN_HEIGHT / 22)
    @small_font  = Gosu::Font.new(self, "Futura", SCREEN_HEIGHT / 30)
    self.caption= "Connect Four!"
  end

  def create_players(p1_difficulty, p2_difficulty)
    @player1 = Player.new(1, p1_difficulty, self, @board_logic)
    @player2 = Player.new(2, p2_difficulty, self, @board_logic)
  end

  def button_down(key)
    case key
    when Gosu::MsLeft
      if in_menu?
        @menu.update_selection(mouse_x, mouse_y)
      elsif humans_turn?
        humans_take_turn(mouse_x, mouse_y)
      end
    when Gosu::KbEscape
      close
    when Gosu::KbSpace
      if game_reset?
        @board = Board.new(self)
        @background = Background.new(self)
        @board_logic = BoardLogic.new(self, @board)
        @state = :menu
      end
    end
  end

  def draw
    @background.draw
    if in_menu?
      @menu.draw
    else
      @board.draw
      end_game if @state == :game_over
      reset_game_display if @state == :reset_menu
    end
  end

  def update
    ais_take_turn if ais_turn?
  end

  def in_gameplay?
    @state.to_s.include?("_turn")
  end

  def game_reset?
    @state == :reset_menu
  end

  def in_menu?
    @state == :menu
  end

  def ais_turn?
    in_gameplay? && current_player.ai?
  end

  def humans_turn?
    in_gameplay? && current_player.human?
  end

  def current_player
    if @state == :player1_turn
      @player1
    elsif @state == :player2_turn
      @player2
    end
  end

  def humans_take_turn(mouse_x, mouse_y)
    col = @board.clicked_col(mouse_x, mouse_y)
    current_player.take_turn(col) if col
  end

  def ais_take_turn
    current_player.take_turn
  end

  def finish_turn
    @board_logic.game_over? ? @state = :game_over : toggle_turn
  end

  def toggle_turn
    @state = ([:player1_turn, :player2_turn] - [@state])[0]
  end

  def end_game
    if @board_logic.tie?
      @result_text = "Game Over: Tie!"
    else
      number = @board_logic.find_winner
      @result_text = "Player #{number} Wins!"
    end
    @state = :reset_menu
  end

  def reset_game_display
    reset_text = "(press space bar to reset game)"
    draw_centered_text(450, @result_text, @big_font, 0xffffffff)
    draw_centered_text(520, reset_text, @small_font, Gosu::Color::RED)
  end

  def draw_centered_text(y, text, font, color)
    x = (SCREEN_WIDTH - font.text_width(text)) / 2
    draw_text(x, y, text, font, color)
  end

  def needs_cursor?
    true
  end

  def draw_text(x, y, text, font, color)
    font.draw(text, x, y, 1, 1, 1, color)
  end
end

#BEGIN PLAY:
game = GameWindow.new
game.show
