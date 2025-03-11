import DiscourseRoute from "discourse/routes/discourse";
import { inject as service } from "@ember/service";

export default class UserOpenaiLinkAnalyzerRoute extends DiscourseRoute {
  @service router;
  @service currentUser;

  beforeModel() {
    if (!this.currentUser) {
      this.router.transitionTo("login");
    }
  }
  
  setupController(controller, model) {
    super.setupController(controller, model);
    controller.setProperties({ user: this.modelFor("user") });
  }
} 