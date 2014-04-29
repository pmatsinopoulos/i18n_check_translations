require 'spec_helper'

describe I18nCheckTranslations do
  describe '.hash_traverse' do
    shared_examples 'successful traversal' do
      it 'successfully traverses' do
        result = I18nCheckTranslations.send :hash_traverse, hash

        expect(result).to eq(expected_result)
      end
    end
    context 'given hash case 1' do
      let(:hash) do
        {:en => {:hello => 'Hello',
                 :world => 'World',
                 :wonderful => {:another => "wonderful",
                                :what => "world"},
                 :what_to => {:do_it => {:i_will_not => 'what is that?',
                                         :you_will   => 'another one'},
                              :redo_it => 'hello redo it'}
        },
         :gr => {:there => 'hello 2',
                 :again => {:what => 'again what on earth'}}
        }
      end
      let(:expected_result) do
        {
            'en.hello'                    => 'Hello',
            'en.world'                    => 'World',
            'en.wonderful.another'        => 'wonderful',
            'en.wonderful.what'           => 'world',
            'en.what_to.do_it.i_will_not' => 'what is that?',
            'en.what_to.do_it.you_will'   => 'another one',
            'en.what_to.redo_it'          => 'hello redo it',

            'gr.there'                    => 'hello 2',
            'gr.again.what'               => 'again what on earth'
        }
      end
      it_behaves_like 'successful traversal'
    end

    context 'given hash case 2' do
      let(:hash) do
        {:en => {:hello => 'Hello'}}
      end
      let(:expected_result) do
        {
            'en.hello'                    => 'Hello'
        }
      end
      it_behaves_like 'successful traversal'
    end

    context 'given hash case 3' do
      let(:hash) do
        {:en => {:hello => {:hello2 => {:hello3 => {:hello4 => 'Hello 4'},
                                        :hello31 => 'Hello 31'},
                            :hello21 => 'Hello 21'},
                 :hello1 => 'Hello 1'}}
      end
      let(:expected_result) do
        {
            'en.hello.hello2.hello3.hello4' => 'Hello 4',
            'en.hello.hello2.hello31'       => 'Hello 31',
            'en.hello.hello21'              => 'Hello 21',
            'en.hello1'                     => 'Hello 1'
        }
      end
      it_behaves_like 'successful traversal'
    end
  end
end