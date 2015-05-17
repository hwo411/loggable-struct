require "spec_helper"
require "core_ext/struct"
require "loggable_struct"

RSpec.describe LoggableStruct do
  Struct.new "TestClass", :foo, :bar do
    def foobar
      "#{@foo} #{@bar}"
    end
  end

  let(:struct) { Struct::TestClass.new foo: 1 }

  before do
    class << struct
      def barfoo
        "#{@bar} #{@foo}"
      end
    end
  end

  RSpec.shared_examples "without refinement" do
    context "when basic Object method is called" do
      it "does not call the logger" do
        expect_any_instance_of(::Logger).not_to receive(:info).with(:to_s)
        struct.to_s
      end
    end

    context "when struct field method is called" do
      it "does not call the logger" do
        expect_any_instance_of(::Logger).not_to receive(:info).with(:foo)
        struct.foo
      end
    end

    context "when method added on struct creation is called" do
      it "does not call the logger" do
        expect_any_instance_of(::Logger).not_to receive(:info).with(:foobar)
        struct.foobar
      end
    end

    context "when method added after object was created is called" do
      it "does not call the logger" do
        expect_any_instance_of(::Logger).not_to receive(:info).with(:barfoo)
        struct.barfoo
      end
    end
  end

  context "when not using the module" do
    it_behaves_like "without refinement"
  end

  context "when using the module" do
    using described_class

    context "when basic Object method is called" do
      it "calls the logger" do
        expect_any_instance_of(::Logger).to receive(:info).with(:to_s).once
        struct.to_s
      end
    end

    context "when struct field method is called" do
      it "calls the logger" do
        expect_any_instance_of(::Logger).to receive(:info).with(:foo).once
        struct.foo
      end
    end

    context "when method added on struct creation is called" do
      it "calls the logger" do
        expect_any_instance_of(::Logger).to receive(:info).with(:foobar).once
        struct.foobar
      end
    end

    context "when method added after object was created is called" do
      it "does not call the logger (not supported)" do
        expect_any_instance_of(::Logger).not_to receive(:info).with(:barfoo)
        struct.barfoo
      end
    end

    context "when Struct subclass is created after using LoggableStruct" do
      Struct.new "TestClassAfter", :foo
      let(:struct_after) { Struct::TestClassAfter.new }

      context "when struct field method is called" do
        it "does not call the logger" do
          expect_any_instance_of(::Logger).not_to receive(:info).with(:foo)
          struct_after.foo
        end
      end

      context "when basic Object method is called" do
        it "calls the logger" do
          expect_any_instance_of(::Logger).to receive(:info).with(:to_s).once
          struct_after.to_s
        end
      end
    end
  end

  context "after using the module in code" do
    begin
      using described_class
    end

    it_behaves_like "without refinement"
  end
end
