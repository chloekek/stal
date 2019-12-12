unit module Stal::Parse;

use Stal::Ast;

my grammar Grammar
{
    method error(Str:D $context --> Nil)
    {
        die qq:to/MESSAGE/;
            Cannot parse $context!
                at file $*path
                on line {self.target.substr(0, self.pos).lines.elems max 1}
                is text ｢{self.target.substr(self.pos).lines[0]}｣
            MESSAGE
    }

    rule TOP
    {
        [$<definitions>=<definition>] *
    }

    proto rule definition {*}

    rule definition:sym<subroutine>
    {
        ‘sub’ [ [$<names>=<identifier>] + || <.error(‘subroutine names’)> ]
        ‘of’  [ $<type>=<block>           || <.error(‘subroutine type’)> ]
        ‘is’  [ $<body>=<block>           || <.error(‘subroutine body’)> ]
        ‘end’
    }

    rule block
    {
        [$<commands>=<command>] *
    }

    proto rule command {*}

    rule command:sym<call>
    {
        $<callee>=<identifier>
    }

    rule command:sym<load>
    {
        ‘?’ $<variable>=<identifier>
    }

    rule command:sym<store>
    {
        ‘!’ $<variable>=<identifier>
    }

    rule command:sym<push-closure>
    {
        “\x7B”
            [ $<body>=<block> || <.error(‘closure body’)> ]
        “\x7D”
    }

    rule command:sym<push-stack-modification>
    {
        ‘(’
            [ $<input>=<block> || <.error(‘input stack’)> ]
        ‘→’
            [ $<output>=<block> || <.error(‘output stack’)> ]
        ‘)’
    }

    token identifier
    {
        [  <:L> <:L+:N+[-]> *
        || <:P+:S-:Pe-:Ps> ]
        <!{ ~$/ ∈ <end is of sub → ? !> }>
    }
}

my class Actions
{
    method TOP($/)
    {
        my @definitions := $<definitions>».made;
        make SourceFile.new(:@definitions);
    }

    method definition:sym<subroutine>($/)
    {
        my @names := $<names>».made;
        my $type  := $<type>.made;
        my $body  := $<body>.made;
        make SubroutineDefinition.new(:@names, :$type, :$body);
    }

    method block($/)
    {
        my @commands := $<commands>».made;
        make Block.new(:@commands);
    }

    method command:sym<call>($/)
    {
        my $callee := $<callee>.made;
        make CallCommand.new(:$callee);
    }

    method command:sym<load>($/)
    {
        my $variable := $<variable>.made;
        make LoadCommand.new(:$variable);
    }

    method command:sym<store>($/)
    {
        my $variable := $<variable>.made;
        make LoadCommand.new(:$variable);
    }

    method command:sym<push-closure>($/)
    {
        my $body := $<body>.made;
        make PushClosureCommand.new(:$body);
    }

    method command:sym<push-stack-modification>($/)
    {
        my $input  := $<input>.made;
        my $output := $<output>.made;
        make PushStackModificationCommand.new(:$input, :$output);
    }

    method identifier($/)
    {
        make ~$/;
    }
}

multi parse-source-file(IO::Path:D $path)
    is export
{
    parse-source-file $path, $path.slurp;
}

multi parse-source-file(IO::Path:D $path, Str:D $source)
    is export
{
    my $*path := $path;
    Grammar.parse($source, actions => Actions).made;
}
