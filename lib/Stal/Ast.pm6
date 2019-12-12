unit module Stal::Ast;

################################################################################
# Roles

role Definition
    is export
{
}

role Command
    is export
{
}

class Block
    is export
{
    has Command:D @.commands;
}

################################################################################
# Source files

class SourceFile
    is export
{
    has Definition:D @.definitions;

    method gist(::?CLASS:D: --> Str:D)
    {
        @.definitions».gist.join(“\n”);
    }
}

################################################################################
# Definitions

class SubroutineDefinition
    is export
    does Definition
{
    has Str:D @.names;
    has Block $.type;
    has Block $.body;

    method gist(::?CLASS:D: --> Str:D)
    {
        qq:to/STAL/.chomp;
            {join(‘ ’, ‘sub’, @!names)}
            {join(‘ ’, ‘of’, $!type.commands».gist)}
            {join(‘ ’, ‘is’, $!body.commands».gist)}
            end
            STAL
    }
}

################################################################################
# Commands

class CallCommand
    is export
    does Command
{
    has Str $.callee;

    method gist(::?CLASS:D: --> Str:D)
    {
        $!callee;
    }
}

class LoadCommand
    is export
    does Command
{
    has Str $.variable;

    method gist(::?CLASS:D: --> Str:D)
    {
        “?$!variable”;
    }
}

class StoreCommand
    is export
    does Command
{
    has Str $.variable;

    method gist(::?CLASS:D: --> Str:D)
    {
        “!$!variable”;
    }
}

class PushClosureCommand
    is export
    does Command
{
    has Block $.body;

    method gist(::?CLASS:D: --> Str:D)
    {
        join ‘ ’, ‘{’, $!body.commands».gist, ‘}’;
    }
}

class PushStackModificationCommand
    is export
    does Command
{
    has Block $.input;
    has Block $.output;

    method gist(::?CLASS:D: --> Str:D)
    {
        join ‘ ’, ‘(’, $!input.commands».gist, ‘→’,
                       $!output.commands».gist, ‘)’;
    }
}
