require 'sinatra'
require 'json'
require 'securerandom'
require 'digest/sha2'

class Block
  attr_accessor :index, :previous_hash, :timestamp, :data, :hash

  def initialize(index, previous_hash, data)
    @index = index
    @previous_hash = previous_hash
    @timestamp = Time.now.to_i
    @data = data
    @hash = calculate_hash
  end

  def calculate_hash
    Digest::SHA256.hexdigest("#{@index}#{@previous_hash}#{@timestamp}#{@data}")
  end
end

class Blockchain
  attr_accessor :chain

  def initialize
    @chain = [create_genesis_block]
  end

  def create_genesis_block
    Block.new(0, '0', 'Genesis Block')
  end

  def add_block(data)
    previous_block = @chain.last
    new_block = Block.new(previous_block.index + 1, previous_block.hash, data)
    @chain << new_block
  end

  def valid_chain?
    @chain.each_cons(2).all? { |previous, current| current.previous_hash == previous.hash }
  end
end

blockchain = Blockchain.new

get '/' do
  'Welcome to the Minimalist Blockchain dApp!'
end

get '/chain' do
  blockchain.chain.to_json
end

post '/add_block' do
  data = params[:data]
  blockchain.add_block(data)
  'Block added successfully!'
end

get '/validate' do
  blockchain.valid_chain? ? 'Chain is valid!' : 'Chain is invalid!'
end