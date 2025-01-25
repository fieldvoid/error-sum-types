module errorSumType;

public import std.sumtype;
import core.attribute;

@mustuse struct Bool {
    bool flag;

    alias this = flag;

    this (bool flag) @nogc {
        this.flag = flag;
    }
}

struct None {
}

None none () @nogc {
    return None();
}

// Commenting this @mustuse until relevant bugfix in DMD is merged for next release.
//@mustuse
struct Maybe (T) {
    SumType!(None, T) value;

    alias this = value;

    this (U) (U value) {
        this.value = value;
    }
}

Maybe!T makeMaybe (T, U) (U value) {
    return Maybe!T(value);
}
