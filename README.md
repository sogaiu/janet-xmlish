# janet-xmlish

PEG-based Parsing for XML-ish Data

## Description and Disclaimer

This code provides a single PEG to help parse XML-like strings to
produce Janet data structures.  It's not an attempt at a complete /
correct parser, but it seems to have handled some cases tolerably
well.

## Usage

### Command Line

Zero to sample invocation:

```
git clone https://github.com/sogaiu/janet-xmlish
cd janet-xmlish
janet -l ./janet-xmlish/grammar -e '(pp (peg/match xmlish-peg "<h1>hi</h1>"))'
```

Output:

```
@[{:content @["hi"] :tag "h1"}]
```

### From Code

Assuming installation like:

```
jpm install https://github.com/sogaiu/janet-xmlish
```

Code might look like:

```
(import janet-xmlish/grammar :as xmlish)

(peg/match xmlish/xmlish-peg
           ``<a href="http://127.0.0.1:8000">link</a>``)
```

Evaluation might yield:
```
@[{:attrs @{"href" "http://127.0.0.1:8000"}
   :content @["link"]
   :tag "a"}]
```

## More Examples

See `(comment ...)` form a bit after the first `def` in [grammar.janet](./janet-xmlish/grammar.janet) for more examples.

