#!/bin/bash

#*******************************************************************
# Script to sign, pack, and notarize an application
# Parameters:
# 1 : Command (sign, pack, notarize)
# 2 : Application path (for sign)
# 3 : Entitlements file path (for sign)
# 4 : Certificate name (for sign)
# 5 : Flag to ignore codesign check (optional, for sign)
# 6 : Source path (for pack)
# 7 : Destination zip file path (for pack)
# 8 : Zip file path (for notarize)
# 9 : Keychain profile (for notarize)
#
# Returns 0 when everything went well
# or another value when there is an error
#*******************************************************************

# Function to check if the certificate exists
# Parameters:
# 1 : Certificate name
#
# Returns: 0 if the certificate exists, 1 otherwise
#*******************************************************************
check_certificate() {
  local certificate="$1"
  if ! security find-identity -v -p codesigning | grep -q "$certificate"; then
    echo "Certificate not found: $certificate"
    return 1
  fi
  return 0
}

# Function to sign the package
# Parameters:
# 1 : Application path
# 2 : Entitlements file path
# 3 : Certificate name
# 4 : Flag to ignore codesign check (optional)
#
# Returns: 0 if signing succeeded, error code otherwise
#*******************************************************************
sign() {
  local path="$1"
  local entitlements_file="$2"
  local certificate="$3"
  local ignore_codesign_check="${4:-true}"

  # Error codes
  local ERR_CONTENTS_NOT_FOUND=1
  local ERR_CERT_NOT_FOUND=2
  local ERR_ENTITLEMENTS_NOT_FOUND=3
  local ERR_CHECK_SIGNATURE_FAILED=4

  # Check if the path exists and contains a Contents directory
  if [ ! -d "$path/Contents" ]; then
    echo "The specified path does not contain a Contents directory."
    return $ERR_CONTENTS_NOT_FOUND
  fi


  # check if ad hoc signature is used
  #if [ "$certificate" == "-" ]; then
  #  echo "Ad hoc signature is used for the application."
  #else
  #  # Check if the certificate exists
  #    if ! check_certificate "$certificate"; then
  #      return $ERR_CERT_NOT_FOUND
  #    fi
  #fi
 
  # Check if the entitlements file exists
  if [ ! -f "$entitlements_file" ]; then
    echo "Entitlements file not found: $entitlements_file"
    return $ERR_ENTITLEMENTS_NOT_FOUND
  fi

  # Recursively sign all directories and files inside Contents
  sign_recursive() {
    local dir="$1"
    for item in "$dir"/*; do
      if [ -d "$item" ]; then
        echo "Signing directory: $item"
        sign_recursive "$item"
      elif [ -e "$item" ]; then
        if [[ "$(basename "$item" | tr '[:upper:]' '[:lower:]')" =~ \.(jpg|jpeg|png|gif|bmp|tiff|webp|md)$ ]]; then
          # echo "Skipping signing for: $item"
          continue
        fi
        echo "Signing item: $item"
        codesign --force --verbose --timestamp --options runtime --entitlements "$entitlements_file" --sign "$certificate" "$item"
        codesign_exit_code=$?
        if [ "$ignore_codesign_check" != "true" ] && [ $codesign_exit_code -ne 0 ]; then
          echo "Failed to sign $item with exit code $codesign_exit_code"
          return $codesign_exit_code
        fi
      fi
    done
  }

  # Start recursive signing from Contents directory
  sign_recursive "$path/Contents"

  # Sign all items inside Contents
  echo "Signing items in Contents directory: $path/Contents"
  for item in "$path/Contents"/*; do
    if [ -e "$item" ]; then
      echo "Signing item: $item"
      codesign --force --verbose --timestamp --options runtime --entitlements "$entitlements_file" --sign "$certificate" "$item"
      codesign_exit_code=$?
      if [ "$ignore_codesign_check" != "true" ] && [ $codesign_exit_code -ne 0 ]; then
        echo "Failed to sign $item with exit code $codesign_exit_code"
        return $codesign_exit_code
      fi
    fi
  done

  # Sign the main package
  codesign --force --verbose --timestamp --options runtime --entitlements "$entitlements_file" --sign "$certificate" "$path"
  codesign_exit_code=$?
  if [ "$ignore_codesign_check" != "true" ] && [ $codesign_exit_code -ne 0 ]; then
    echo "Failed to sign the main package with exit code $codesign_exit_code"
    return $codesign_exit_code
  fi

 # Check signature
  echo "Checking signature of $path"
  codesign -v "$path"
  if [ $? -ne 0 ]; then
    echo "Failed to check signature of $path"
    return $ERR_CHECK_SIGNATURE_FAILED
  fi

  echo "All directories and items have been signed."
  return 0
}

# Function to pack the path into a zip file using ditto
# Parameters:
# 1 : Source path
# 2 : Destination zip file path
#
# Returns: 0 if packing succeeded, error code otherwise
#*******************************************************************
pack() {
  local source_path="$1"
  local destination_zip="$2"

  # Error codes
  local ERR_SOURCE_NOT_FOUND=1

  # Check if the source path exists
  if [ ! -d "$source_path" ]; then
    echo "Source path not found: $source_path"
    return $ERR_SOURCE_NOT_FOUND
  fi

  echo "Packing $source_path into $destination_zip"
  ditto -ckX --rsrc --keepParent --zlibCompressionLevel 9 "$source_path" "$destination_zip"
  ditto_exit_code=$?
  if [ $ditto_exit_code -ne 0 ]; then
    echo "Failed to pack $source_path into $destination_zip with exit code $ditto_exit_code"
    return $ditto_exit_code
  fi

  return 0
}

# Function to notarize the package
# Parameters:
# 1 : Zip file path
# 2 : Keychain profile
#
# Returns: 0 if notarization succeeded, error code otherwise
#*******************************************************************
notarize() {
  local zip_file="$1"
  local keychain_notary="$2"

  # Error codes
  local ERR_ZIP_NOT_FOUND=1
  local ERR_NOTARYTOOL_NOT_FOUND=2
  local ERR_NOTARIZATION_FAILED=3

  # Check if the zip file exists
  if [ ! -f "$zip_file" ]; then
    echo "Zip file not found: $zip_file"
    return $ERR_ZIP_NOT_FOUND
  fi

  # Check if keychain_notary is installed
  if ! xcrun --find notarytool &> /dev/null; then
    echo "notarytool is not installed. Please install Xcode Command Line Tools."
    return $ERR_NOTARYTOOL_NOT_FOUND
  fi

  echo "Notarizing $zip_file"
  result=$(xcrun notarytool submit "$zip_file" --keychain-profile "$keychain_notary" --wait)

  if echo "$result" | grep -q "Accepted"; then
    echo "Notarization accepted."
    return 0
  else
    echo "Notarization failed."
    return $ERR_NOTARIZATION_FAILED
  fi
}

# Check if the arguments are provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <command> [args...]"
  echo "Commands:"
  echo "  sign <path> <entitlements_file> <certificate> [ignore_codesign_check]"
  echo "  pack <source_path> <destination_zip>"
  echo "  notarize <zip_file> <keychain_notary>"
  exit 1
fi

# Execute the appropriate function based on the command
command="$1"
shift

case "$command" in
  sign)
    if [ $# -lt 3 ] || [ $# -gt 4 ]; then
      echo "Usage: $0 sign <path> <entitlements_file> <certificate> [ignore_codesign_check]"
      exit 1
    fi
    ignore_codesign_check="true"
    if [ $# -eq 4 ]; then
      ignore_codesign_check="$4"
    fi
    sign "$1" "$2" "$3" "$ignore_codesign_check"
    ;;
  pack)
    if [ $# -ne 2 ]; then
      echo "Usage: $0 pack <source_path> <destination_zip>"
      exit 1
    fi
    pack "$1" "$2"
    ;;
  notarize)
    if [ $# -ne 2 ]; then
      echo "Usage: $0 notarize <zip_file> <keychain_notary>"
      exit 1
    fi
    notarize "$1" "$2"
    ;;
  *)
    echo "Unknown command: $command"
    echo "Usage: $0 <command> [args...]"
    echo "Commands:"
    echo "  sign <path> <entitlements_file> <certificate> [ignore_codesign_check]"
    echo "  pack <source_path> <destination_zip>"
    echo "  notarize <zip_file> <keychain_notary>"
    exit 1
    ;;
esac