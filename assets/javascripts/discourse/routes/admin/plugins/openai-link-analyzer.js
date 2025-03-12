import DiscourseRoute from "discourse/routes/discourse";

export default class AdminPluginsOpenaiLinkAnalyzerRoute extends DiscourseRoute {
  setupController(controller) {
    controller.loadStatistics();
  }
  
  resetController(controller, isExiting) {
    if (isExiting) {
      controller.set("stats", null);
      controller.set("loading", true);
      controller.set("apiTestResult", null);
    }
  }
} 