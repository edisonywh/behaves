RSpec.describe Behaves do
  it 'has a version number' do
    expect(Behaves::VERSION).not_to be nil
  end

  before do
    monkey_patch_behaves
    Dog = Class.new
    Animal = Class.new

    Interface = Class.new
    Implementor = Class.new
  end

  after do
    class_cleaner(Animal, Dog, Interface, Implementor)
  end

  context 'when `Dog` is supposed to behave like `Animal`' do
    before do
      Animal.class_eval do
        implements :method_one, :method_two
        implements :method_three
      end
    end

    context 'via public methods' do
      context 'when `Dog` implements behavior' do
        it 'should not raise error' do
          class Foo
            # behaves_like Animal

            private
            def method_one; end
          end

          expect do
            Dog.class_eval do
              behaves_like Animal

              def method_one; end
              def method_two; end
              def method_three; end
            end
          end.not_to raise_error
        end
      end

      context 'when `Dog` does not implement behavior' do
        it 'should raise NotImplementedError' do
          expect do
            Dog.send(:check_for_unimplemented, Animal, :public) # Since I can't test `at_exit`, I'm testing the private method directly.
          end.to raise_error NotImplementedError, %r"Expected `Dog` to behave like `Animal`, but the following public methods.+`method_one`.+`method_two`.+`method_three`"m
        end
      end
    end
  end

  context 'when `Dog` is not supposed to behave like `Animal`' do
    it 'should not raise any error' do
      expect do
        Dog.class_eval do
          def method_one; end
          def method_two; end
          def method_three; end
        end
      end.not_to raise_error
    end
  end

  context 'when `Animal` does not implement behavior' do
    context 'when `Dog` adheres to a non-existent `Animal` behavior' do
      it 'should raise error' do
        expect do
          Dog.send(:check_for_unimplemented, Animal, :public) # Since I can't test `at_exit`, I'm testing the private method directly.
        end.to raise_error NotImplementedError, "Expected `Animal` to define behaviors, but none found."
      end
    end
  end

  context "when Animal injects" do
    context "public behavior to Dog" do
      before do
        Animal.class_eval do
          implements :method_one

          inject_behaviors do
            def greet
              "hello"
            end
          end
        end

        Dog.class_eval do
          behaves_like Animal

          def method_one; end
        end
      end

      it "should have the injected behavior" do
        expect(Dog.instance_methods).to include(:greet)
      end

      it "should return the correct output when invoked" do
        expect(Dog.new.greet).to eq("hello")
      end
    end

    context "public behavior to Dog, but Dog has a function with the same name defined" do
      before do
        Animal.class_eval do
          implements :method_one

          inject_behaviors do
            def greet
              "hello"
            end
          end
        end

        Dog.class_eval do
          behaves_like Animal

          def method_one; end

          def greet
            "bonjour"
          end
        end
      end

      it "should return the correct output from the function defined in Dog instead" do
        expect(Dog.new.greet).to eq("bonjour")
      end
    end
  end

  context "when Animal injects" do
    context "private behavior to Dog" do

      before do
        Animal.class_eval do
          implements :method_one

          inject_behaviors do
            private

            def greet
              "hello"
            end
          end
        end

        Dog.class_eval do
          behaves_like Animal

          def method_one; end
        end
      end

      it "should have the injected behavior" do
        expect(Dog.private_instance_methods).to include(:greet)
      end

      it "should return the correct output when invoked" do
        expect(Dog.new.send(:greet)).to eq("hello")
      end
    end

    context "private behavior to Dog, but Dog has a private function defined with the same name" do
      before do
        Animal.class_eval do
          implements :method_one

          inject_behaviors do
            private

            def greet
              "hello"
            end
          end
        end

        Dog.class_eval do
          behaves_like Animal

          def method_one; end

          private

          def greet
            "bonjour"
          end
        end
      end

      it "should return the correct output when invoked" do
        expect(Dog.new.send(:greet)).to eq("bonjour")
      end
    end

    context "injecting to include module" do
      TestModule = Module.new

      before do
        TestModule.module_eval do
          def greet
            "hello"
          end
        end

        Animal.class_eval do
          implements :method_one

          inject_behaviors do
            include TestModule
          end
        end

        Dog.class_eval do
          behaves_like Animal

          def method_one; end
        end
      end

      it "should add greet as an instance method to Dog" do
        expect(Dog.instance_methods).to include(:greet)
      end

      it "should return the correct result when greet is invoked from Dog" do
        expect(Dog.new.greet).to eq("hello")
      end
    end

    context "injecting to extend a module" do
      TestModule = Module.new

      before do
        TestModule.module_eval do
          def greet
            "hello"
          end
        end

        Animal.class_eval do
          implements :method_one

          inject_behaviors do
            extend TestModule
          end
        end

        Dog.class_eval do
          behaves_like Animal

          def method_one; end
        end
      end

      it "should add greet as a class method to Dog" do
        expect(Dog.methods).to include(:greet)
      end

      it "should return the correct result when greet is invoked from Dog" do
        expect(Dog.greet).to eq("hello")
      end
    end
  end

  context 'private behaviors' do
    before do
      Interface.class_eval do
        implements :foo
        implements :bar, private: true
      end
    end

    context 'when implemented' do
      it 'raises no errors' do
        expect do
          Implementor.class_eval do
            def foo; end

            private

            def bar; end
          end

          Implementor.send(:check_for_unimplemented, Interface, :public)
          Implementor.send(:check_for_unimplemented, Interface, :private)
        end.not_to raise_error
      end

      context 'but in the wrong scope' do
        it 'raises an error' do
          expect do
            Implementor.class_eval do
              def foo; end
              def bar; end
            end

            Implementor.send(:check_for_unimplemented, Interface, :public)
            Implementor.send(:check_for_unimplemented, Interface, :private)
          end.to raise_error NotImplementedError, %r(private methods.+`bar`.+appear to be defined, but in the wrong scope.+`bar`)m
        end
      end
    end

    context 'when unimplemented' do
      it 'raises an error' do
        expect do
          Implementor.class_eval do
            def foo; end
          end

          Implementor.send(:check_for_unimplemented, Interface, :public)
          Implementor.send(:check_for_unimplemented, Interface, :private)
        end.to raise_error NotImplementedError, %r(private methods.+`bar`)m
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
