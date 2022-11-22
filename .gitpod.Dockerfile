FROM gitpod/workspace-full

USER gitpod

# Install Julia
RUN pip install jill
RUN jill install --confirm
RUN julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.precompile()"


# Give control back to Gitpod Layer
USER root

