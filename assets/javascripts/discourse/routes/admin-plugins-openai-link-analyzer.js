import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  controllerName: "admin-openai-link-analyzer",
  
  renderTemplate() {
    this.render("admin/openai-link-analyzer");
  },

  model() {
    return {};
  },
  
  setupController(controller, model) {
    this._super(controller, model);
    controller.loadStats();
  }
}); 