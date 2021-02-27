// Pipeline Configuration Properties
// Import this file into the pipeline using 'load'.
class config extends bc.baseConfig {
  // Build configuration
  public static final String[] BUILDS = ["web-runtime", "web-artifacts", "web", "api"]
}

return new config();