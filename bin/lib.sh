readonly COMPAT_CACHE_DIR=${HOME}/.uberloader-compatibility-test
readonly COMPAT_RESULTS_DIR=${COMPAT_CACHE_DIR}/results

function gem_versions {
  gem info $1 --remote --all --prerelease | awk '$1 == "'$1'"' | sed 's/.*(//' | sed 's/)$//' | sed 's/, /\n/g'
}

function gem_dependency_constraints {
  gem_name=$1
  gem_v=$2
  dep_name=$3
  gem dependency $gem_name -v $gem_v --remote | awk -v "dep=$dep_name" '$1 == dep { sub(/.+\(/, ""); sub(/\)$/, ""); print $0}'
}

function version_satisfies {
  V=$1 C="$2" ruby -e '
    def main
      version = ENV.fetch("V")
      constraints = ENV.fetch("C").split(", ")
      constraints.all? { |c| satisfies? c, version } ? 0 : 1
    end

    # NOTE handling of pre-release versions probably isnt right
    def satisfies?(constraint, v)
      case constraint
      when /^ *= *(\d.+)/
        v == $1
      when /^ *\^ *(\d.+)/
        v >= $1 && v.split(".")[0].to_i == $1.split(".")[0].to_i
      when /^ *~ *(\d.+)/
        v >= $1 && v.split(".")[1].to_i == $1.split(".")[1].to_i
      when /^ *~> *(\d.+)/
        c = $1.split "."
        v = v.split "."
        n = c.size - 1
        c[0,n] == v[0,n] && v[n..].join(".") >= c[n..].join(".")
      when /^ *(>|>=|<|<=) *(\d.+)/
        v.send($1, $2)
      else
        false
      end
    end

    exit main
  '
}

function compat_image_name {
  suffix=$1
  echo "uberloader-compat-${suffix}"
}

function podpose {
  if [[ -n "${PODMAN-}" ]]; then
    podman-compose "$@"
  else
    docker compose "$@"
  fi
}

function array_in_array {
  args=("$@")
  term_size=${args[0]}
  terms=("${args[@]:1:$term_size}")
  array=("${args[@]:$(($term_size+1))}")

  for x in ${terms[@]}; do
    if ! in_array $x ${array[@]}; then
      return 1
    fi
  done
  return 0
}

function in_array {
  term=$1
  shift 1
  for x in $@; do [[ $term == $x ]] && return 0; done
  return 1
}

function announce {
  box="#############################################################"
  printf "\n%s\n  %s\n%s\n" $box "$@" $box
}

function nyancat {
  red='\e[31m'
  green='\e[32m'
  yellow='\e[33m'
  blue='\e[34m'
  bold='\033[1m'
  normal='\e[0m'

  lines=(
    ""
    "+      o     +              o"
    "    +             o     +       +"
    "o          +"
    "    o  +           +        +"
    "+        o     o       +        o"
    "${red}-_-_-_-_-_-_-_${normal},------,      o "
    "${yellow}_-_-_-_-_-_-_-${normal}|   /\\_/\\  "
    "${green}-_-_-_-_-_-_-${normal}~|__( ^ .^)  +     +  "
    "${blue}_-_-_-_-_-_-_-${normal}\"\"  \"\"      "
    "    +      o         o   +       o"
    "    +         +"
    "o        o         o      o     +"
    "    o           +"
    "+      +     o        o      +    "
    ""
  )

  for line in "${lines[@]}"; do
    printf "${line}\n"
  done
}
