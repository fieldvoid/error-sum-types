import std.stdio;
import std.sumtype;

struct None {
}

struct Maybe (T) {
    SumType!(None, T) obj;

    alias this = obj;

    this (None none) {
        this.obj = none;
    }

    this (T t) {
        this.obj = t;
    }

    this (Maybe!T maybe) {
        this.obj = maybe.obj;
    }

    // Maybe!A -> (A -> Maybe!B) -> Maybe!B
    auto bind (F) (F fn) {
        static if (is(F params == __parameters) && is(F ret == return)) {
            static assert(params.length == 1, "Callable object must have an arity of 1.");
            static if (is(ret: Maybe!V, V)) {
                static if (is(params[0] == T)) {
                    return obj.match!(
                        (T t) => fn(t),
                        (None none) => this,
                    );
                }
                else static if (is(params[0] == None)) {
                    return obj.match!(
                        (T t) => this,
                        (None none) => fn(none),
                    );
                }
                else {
                    static assert(0, "Argument is a callable object but its transformer does not operate on the lifted types.");
                }
            }
            else {
                static assert(0, "Argument is a callable object but does not lift to the Maybe dimension.");
            }
        }
        else static if (is(typeof(__traits(getMember, F, "opCall")) opCallType)) {
            static if (is(opCallType params == __parameters) && is(opCallType ret == return)) {
                static assert(params.length == 1, "Callable object must have an arity of 1.");
                static if (is(ret: Maybe!V, V)) {
                    static if (is(params[0] == T)) {
                        return obj.match!(
                            (T t) => fn(t),
                            (None none) => this,
                        );
                    }
                    else static if (is(params[0] == None)) {
                        return obj.match!(
                            (T t) => this,
                            (None none) => fn(none),
                        );
                    }
                    else {
                        static assert(0, "Argument is a callable object but its transformer does not operate on the lifted types.");
                    }
                }
                else {
                    static assert(0, "Argument is a callable object but does not lift to the Maybe dimension.");
                }
            }
            else {
                static assert(0, "Argument must be a callable object that lifts to the Maybe dimension.");
            }
        }
        else {
            static assert(0, "Argument must be either a function or object that has `opCall` defined.");
        }
    }
}

Maybe!T nothing (T) () {
    return Maybe!T(None());
}

Maybe!T just (T) (T something) {
    return Maybe!T(something);
}

version (unittest)
{
    Maybe!int divide (int a, Maybe!int b) {
        return b.match!(
            (int x) => x == 0 ? nothing!int : just(a / x),
            (None y) => nothing!int,
        );
    }

    Maybe!int print (Maybe!int maybe) {
        maybe.writeln;
        return maybe;
    }
}

version (unittest)
{
    void main () {
        1000.just
            .bind((int a) => a.divide(2.just))
            .print // 500
            .bind((int a) => a.divide(0.just))
            .print // None()
            .bind((int a) => a.divide(5.just))
            .print // None()
        ;

        writeln;

        1000.just
            .bind((int a) => a.divide(2.just))
            .print
            .bind((int a) => a.divide(5.just))
            .print
            .bind((int a) => a.divide(0.just))
            .print
        ;
    }
}
