RSpec.describe Behaves do
  it 'has a version number' do
    expect(Behaves::VERSION).not_to be nil
  end

  before do
    monkey_patch_behaves
    Dog = Class.new
    Animal = Class.new
  end

  after do
    class_cleaner(Animal, Dog)
  end

  context 'when `Dog` is supposed to behave like `Animal`' do
    before do
      Animal.class_eval do
        implements :method_one, :method_two
      end
    end

    context 'when `Dog` implements behavior' do
      it 'should not raise error' do
        expect do
          Dog.class_eval do
            behaves_like Animal

            def method_one; end
            def method_two; end
          end
        end.not_to raise_error
      end
    end

    context 'when `Dog` does not implement behavior' do
      it 'should raise NotImplementedError' do
        expect do
          Dog.send(:check_for_unimplemented, Animal) # Since I can't test `at_exit`, I'm testing the private method directly.
        end.to raise_error NotImplementedError, "Expected `Dog` to behave like `Animal`, but `method_one, method_two` are not implemented."
      end
    end
  end

  context 'when `Dog` is not supposed to behave like `Animal`' do
    it 'should not raise any error' do
      expect do
        Dog.class_eval do
          def method_one; end
          def method_two; end
        end
      end.not_to raise_error
    end
  end

  context 'when `Animal` does not implement behavior' do
    context 'when `Dog` adheres to a non-existent `Animal` behavior' do
      it 'should raise error' do
        expect do
          Dog.send(:check_for_unimplemented, Animal) # Since I can't test `at_exit`, I'm testing the private method directly.
        end.to raise_error NotImplementedError, "Expected `Animal` to define behaviors, but none found."
      end
    end
  end

  private

  def monkey_patch_behaves
    Object.send(:extend, Behaves)
  end

  def class_cleaner(*klasses)
    klasses.each { |klass| Object.send(:remove_const, "#{klass}") if defined? klass }
  end
end
