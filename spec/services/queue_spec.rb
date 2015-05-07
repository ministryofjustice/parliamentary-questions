require 'spec_helper'

describe MailService::Queue do
  let(:q) { MailService::Queue.new }

  before(:each) do
    3.times {|n| q.enqueue(n) }
  end

  it '#dequeue - removes the element at the front of the queue' do
    expect(q.dequeue).to eq 0
    expect(q.size).to eq 2
  end

  it '#enqueue - adds an element to the back of the queue' do
    q.enqueue(5)
    3.times { q.dequeue }

    expect(q.peek).to eq 5 
  end

  it '#peek - reveals the first element in the queue' do
    expect(q.peek).to eq 0
  end

  it '#size - returns the size of the queue' do
    expect(q.size).to eq 3
    
    q.enqueue(1)
    expect(q.size).to eq 4
  end

  it '#empty? - returns whether or not the queue is empty' do
    expect(q).not_to be_empty

    3.times { q.dequeue }
    expect(q).to be_empty
  end
end