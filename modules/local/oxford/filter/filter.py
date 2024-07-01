import sys
import yaml

fasta = sys.argv[1]
oxford_poly_context = sys.argv[2]
oxford_max_poly_run = sys.argv[3]

ContextFilter = {   'AlnContext': {'Ref': fasta,
                    'LeftShift': int(f"-{(oxford_poly_context)}"),
                    'RightShift': int(oxford_poly_context),
                    'RegexEnd': f"[Aa]{int(oxford_max_poly_run),}",
                    'Stranded': True,
                    'Invert': True,
                    'Tsv': "alignments/internal_priming_fail.tsv"}}

filter_context = lambda x: ContextFilter

with open("output.yaml", "w") as file:
    yaml.dump(ContextFilter, file, sort_keys=False)
sys.stdout.write(str(filter_context))
sys.exit(0)
