RSpec.describe Behaves do
  it 'has a version number' do
    expect(Behaves::VERSION).not_to be nil
  end

  context 'when `Dog` is supposed to behave like `Animal`' do
    before do
      Animal = Class.new

      Animal.class_eval do
        extend Behaves

        implements :method_one, :method_two
      end
    end

    after do
      class_cleaner(Animal, Dog)
    end

    context 'when `Dog` implements behavior' do
      it 'should not raise error' do
        Dog = Class.new

        expect do
          Dog.class_eval do
            extend Behaves

            behaves_like Animal

            def method_one; end
            def method_two; end
          end
        end.not_to raise_error
      end
    end

    context 'when `Dog` does not implement behavior' do
      it 'should raise NotImplementedError' do
        skip "Skipping because the code implementation (`at_exit`) conflicts with rspec's `raise_error`. See https://github.com/rspec/rspec/issues/42"
        Dog = Class.new

        expect do
          Dog.class_eval do
            extend Behaves

            behaves_like Animal
          end
        end.to raise_error NotImplementedError
      end
    end
  end

  def class_cleaner(*klasses)
    klasses.each { |klass| Object.send(:remove_const, "#{klass}") unless defined? klass }
  end

  # def load_class(klass, behaves: false)
  #   klass.class_eval do
  #     extend Behaves

  #     if behaves
  #       behaves_like Animal
  #     end
  #   end
  # end

  # context 'when `Dog` is not supposed to behave like `Animal`' do
  #   it 'should not raise any error' do
  #   end
  # end

  # context 'when `Animal` does not implement behavior' do
  #   context 'when `Dog` adheres to a non-existent `Animal` behavior' do
  #     it 'should raise error' do
  #     end
  #   end
  # end
end
