module MailService
  class Queue
    def initialize
      @store = []
    end

    def dequeue
      @store.pop
    end 

    def enqueue(element)
      @store.unshift(element)
      self
    end

    def peek
      @store.last
    end

    def size
      @store.size
    end

    def empty?
      @store.empty?
    end
  end
end
