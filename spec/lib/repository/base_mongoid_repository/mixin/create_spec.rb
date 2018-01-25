# frozen_string_literal: true

RSpec.describe Atlas::Repository::BaseMongoidRepository::Mixin::Create, type: :repository do

    describe '#update' do
      let(:incluing_class) do
        Class.new do
          include Atlas::Repository::BaseMongoidRepository::Mixin::Create
        end
      end
  
      let(:instance) { incluing_class.new }
  
      subject { instance.create(entity) }
  
      let(:params) { {} }
      let(:entity) { double(:entity) }
      let(:model) { double(:result) }

      before do
        allow(instance).to receive(:error)
        allow(instance).to receive(:wrap).and_yield
        allow(entity).to receive(:is_a?).and_return(true)
        allow(entity).to receive(:to_h).and_return({})
        allow(entity).to receive(:identifier)
        allow(instance).to receive(:model).and_return(model)
      end
  
      it 'applies statements' do
        expect(model).to receive(:create)
        subject
      end
    end
  end
  