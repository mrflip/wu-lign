
## wulign -- format a tab-separated file as aligned columns

wulign will intelligently reformat a tab-separated file into a tab-separated, space aligned file that is still suitable for further processing. For example, given the log-file input

    # cat tag_usage.tsv
    2009-07-21T21:39:40 day     65536   3.15479 68750   1171316
    2009-07-21T21:39:45 doing   65536   1.04533 26230   1053956
    2009-07-21T21:41:53 hapaxlegomenon  65536   0.87574e-05     23707   10051141
    2009-07-21T21:44:00 concert      0.29290    9733414
    2009-07-21T21:44:29 world   65536   1.09110 32850   200916
    2009-07-21T21:44:39 world+series    65536   0.49380 9929    7972025
    2009-07-21T21:44:54 iranelection    65536   2.91775 14592   136342

wulign will reformat it to read

    # cat tag_usage.tsv | wu-lign
    2009-07-21T21:39:40 day                   65536   3.154791234 68750    1171316
    2009-07-21T21:39:45 doing                 65536   1.045330000 26230    1053956
    2009-07-21T21:41:53 hapaxlegomenon        65536   0.000008757 23707   10051141
    2009-07-21T21:44:00 concert                       0.292900000          9733414
    2009-07-21T21:44:29 world                 65536   1.091100000 32850     200916
    2009-07-21T21:44:39 world+series          65536   0.493800000  9929    7972025
    2009-07-21T21:44:54 iranelection          65536   2.917750000 14592     136342

Why this is cool:

* The fields are still tab-delimited by exactly the same numbers of tabs -- only spaces are used to pad out fields. 
  - So it's still a TSV: you can still use cut and friends to manipulate columns.
  - The interventions are limited to padding with spaces and reformatting numeric values. Splitting on tabs and stripping spaces from each field should give essentially the same as the original input.
* empty values are rendered as empty
* the column with mixed scientific notation and plain decimal numbers was rendered uniformly
* text columns were left-aligned; number columns right-aligned
* it figureded out the widths by itself


### Command-line arguments

You can give sprintf-style positional arguments on the command line that will be applied to the corresponding columns. (Blank args are used for placeholding and auto-formatting is still applied).  So with the example above,

    cat foo | wulign  '' '' '' '%8.4e'

will format the fourth column with "%8.4e", while the first three columns and
fifth-and-higher columns are formatted as usual.

    ...
    2009-07-21T21:39:45 doing           65536   1.0453e+00      26230    1053956
    2009-07-21T21:41:53 hapaxlegomenon  65536   8.7574e-06      23707   10051141
    2009-07-21T21:44:00 concert           500   2.9290e-01      13367    9733414
    ....

### How it works

Wu-lign takes the first 500ish lines, splits into fields on TAB characters,
and tries to guess the format (int, float, or string) for each. It builds a
consensus of the width and type for corresponding columns in the chunk.  If a
column has mixed numeric and string formats it degrades to :mixed, which is
basically treated as :string. If a column has mixed :float and :int elements all
of them are formatted as float.

### Notes

* Header rows: the first line is used for width alignment but not for type detection. This means that an initial row of text headers will inform column spacing but still allow a column of floats (say) to be properly aligned as floats.

* It requires a unanimous vote. One screwy line can coerce the whole mess to :mixed; width formatting will still be applied, though.

* It won't set columns wider than 100 chars -- this allows for the occasional super-wide column without completely breaking your screen.

* For :float values, wulign tries to guess at the right number of significant digits to the left and right of the decimal point.

* wulign parses only plain-jane 'TSV files': 
  - no quoting or escaping; 
  - every tab delimits a field;
  - every newline delimits a record.

wulign isn't intended to be smart, or correct, or reliable. It is intended only to be useful for previewing and organizing tab-formatted files. In general wulign(foo).split("\t").map(&:strip) *should* give output semantically equivalent to its input. (That is, the only changes should be insertion of spaces and re-formatting of numerics.) But still -- reserve its use for human inspection only.
