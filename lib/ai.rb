class AI < Player
  attr_reader :difficulty # , :rank_guide
  attr_accessor :col_rank
  def initialize( number, image, board_logic, window, difficulty)
    super( number, image, board_logic, window)
    @board_logic = board_logic
    # goal_patterns = [["XXXX"],
    #                 ["0XXX", "X0XX", "XX0X", "XXX0"],
    #                 ["00XX", "0X0X", "0XX0", "X0X0", "XX00"]]  # to recognize patterns
    # pos_pats = gen_ai_patterns(@window.deep_copy(goal_patterns), number)
    # neg_pats = gen_ai_patterns(@window.deep_copy(goal_patterns), opponent_number)
    #           # [0]=num moves ahead, [1]=add value(if AI move) [2]=add value(opponent move)
    # @rank_guide = [[1, 1050, 1000], [2, 100, 70], [3, 20, 0]].zip(pos_pats, neg_pats)
    @difficulty = difficulty
    @ai_picker = AIPicker.new(self, window, board_logic)
  end

  def take_turn
    #reset baseline column rankings for each turn
    @col_rank  = [[0, 10], [1, 21], [2, 30], [3, 40], [4, 31], [5, 20], [6, 11]]
    add_rank_noise unless expert?
    @ai_picker.pick_col_for_AI
  end

  def add_rank_noise
    @col_rank.each  { |rank| rank[1] += rand(-10..20) }
  end

  def expert?
    @difficulty == @window.expert_difficulty
  end
end
