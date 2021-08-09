require 'open-uri'

class GamesController < ApplicationController

  def start
    def generate_grid(grid_size)
      Array.new(grid_size) { ('A'..'Z').to_a.sample }
    end
    @new_grid = generate_grid(9)
    @start_time = Time.now
  end

  def result

    def english_word?(word)
      response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
      json = JSON.parse(response.read)
      return json['found']
    end

    def included?(guess, grid)
      guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
    end

    def compute_score(attempt, time_taken)
      time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
    end

    def score_and_message(attempt, grid, time)
      if included?(attempt.upcase, grid)
        if english_word?(attempt)
          score = compute_score(attempt, time)
          [score, "well done"]
        else
          [0, "not an english word"]
        end
      else
        [0, "not in the grid"]
      end
    end

    def run_game(attempt, grid, start_time, end_time)
      result = { time: end_time - start_time }
      score_and_message = score_and_message(attempt, grid, result[:time])
      result[:score] = score_and_message.first
      result[:message] = score_and_message.last

      result
    end

    # @start_time = Timestamp.valueOf(params[:start_time])
    @start_time = Time.now
    sleep(2)
    @end_time = Time.now
    @attempt = params[:result]
    @grid = params[:new_grid]
    @score = run_game(@attempt, @grid, @start_time, @end_time)
  end
end
