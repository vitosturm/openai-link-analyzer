export default {
  resource: "admin.adminPlugins",
  path: "/plugins",
  map() {
    this.route("openaiLinkAnalyzer", { path: "/openai-link-analyzer" });
  }
}; 