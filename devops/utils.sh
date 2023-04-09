export REPO_NAME=${REPO_NAME}
export REPO_TYPE=${REPO_TYPE}
export GITHUB_ORG=${GITHUB_ORG}


TEMPLATE="service"
if [ "$REPO_TYPE" == "shared" ]
then
    TEMPLATE="library"
fi

link_to_cruft() {
  echo ""
  echo "-------------------------------------------------------"
  echo "Linking template to cruft.."

  cd ..
  cruft link git@github.com:${GITHUB_ORG}/dev-repositories-manager.git --checkout main --no-input --directory "templates/${TEMPLATE}" --extra-context "{\"repo_name\": "\"${REPO_NAME}"\", \"repo_type\": "\"${REPO_TYPE}"\"}" &&
  echo "cruft file:" &&
  cat .cruft.json
}

update_template_code() {
  echo ""
  echo "-------------------------------------------------------"
  echo "Updating template code using cruft.."

  CRUFT_CONF_FILE=".cruft.json"
  if [ ! -f "$CRUFT_CONF_FILE" ]; then
      echo "repo is not linked to cruft."
      link_to_cruft
  fi

  cruft update --skip-apply-ask --allow-untracked-files
}

$1
