#!/bin/bash
# sambamba_coverage_uniformity 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

# Exit at any point if there is any error and output each line as it is executed (for debugging)
set -e -x -o pipefail

echo $selected_project

main() {
    # SET VARIABLES
    # Store the API key. Grants the script access to DNAnexus resources    
    API_KEY=$(dx cat project-FQqXfYQ0Z0gqx7XG9Z2b4K43:mokaguys_nexus_auth_key)
    # Capture the project runfolder name. Names the multiqc HTML input and builds the output file path
    
    # Assign coverage report output directory name to variable and create (Hard coded)
    outdir=coverage/uniformity_metrics && mkdir -p ${outdir}

    # Sambamba files for are stored at 'selected_multiqc:coverage/raw_output/''. Download the contents of this folder.
    dx download ${selected_project}:coverage/raw_output/* --auth ${API_KEY}

    # Call the docker image. This image is saved as a compressed tarball on DNAnexus, bundled with the app.
    # Download the docker tarball - graemesmith_uniform_coverage.tar.gz
    dx download project-ByfFPz00jy1fk6PjpZ95F27J:file-Fgk3QZ00jy1bjJxG4V7B6jpj

    # Give all users access to docker.sock
    sudo chmod 666 /var/run/docker.sock

    # Load docker image from tarball
    docker load < graemesmith_uniform_coverage.tar.gz

    # The docker -v flag mounts a local directory to the docker environment in the format:
    #    -v local_dir:docker_dir
    docker run -v /home/dnanexus:/home --rm graemesmith/uniform-coverage Rscript "/src/sambamba_exon_coverage.R"  "/home" "/home/coverage/uniformity_metrics"

    # Upload results to DNA nexus
    dx upload /home/dnanexus/coverage/uniformity_metrics --recursive --path $selected_project:coverage/uniformity_metrics
}
