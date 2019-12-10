<?php
namespace AdminModule;

use App\Model;

/** @resource Admin */
class ProfilePresenter extends \BasePresenter
{
    private $mdSchema;
    private $mdProfile;

	public function startup()
	{
		parent::startup();
        $this->mdSchema = new \App\Model\StandardSchemaModel($this->context->getByType('Nette\Database\Context'));
        $this->mdProfile = new \App\AdminModel\ProfileModel($this->context->getByType('Nette\Database\Context'), $this->user);
        $this->mdProfile->setMpttModel($this->mdSchema);
	}

    /** @resource Admin */
	public function renderDefault($id)
	{
        $md_standard = NULL;
        $node = NULL;
        $tmp = explode(',', $id);
        if (count($tmp) === 2) {
            $md_standard = $tmp[0];
            $node = $tmp[1];
        }
        if ($md_standard === NULL) {
            $this->template->mdStandard = $this->mdSchema->getMdStandards();
            $this->setView('SelectStandard');
        } else {
            $this->mdSchema->setMdStandard($md_standard);
            $this->template->mdStandard = $this->mdSchema->getMdStandard($md_standard);
            $this->template->pathEl = $this->mdSchema->getParentNodes($node);
            $this->template->listEl = $this->mdSchema->getTree($node);
            $this->template->profil = $this->mdProfile->getProfil($md_standard, $this->template->listEl);
            $this->template->id = $id;
        }
	}
    
    /** @resource Admin */
    public function actionSet($id) 
    {
        $node = $this->mdProfile->setProfil($id);
        $this->redirect(':Admin:Profile:default', $node);
    }

    /** @resource Admin */
    public function actionUnset($id)
    {
        $node = $this->mdProfile->unsetProfil($id);
        $this->redirect(':Admin:Profile:default', $node);
    }

    /** @resource Admin */
    public function actionAdd()
    {
        $post = $this->context->getByType('Nette\Http\Request')->getPost();
        //dump($post); $this->terminate();
        $md_standard = NULL;
        $node = NULL;
        $profil = NULL;
        $tmp = explode(',', $post['id']);
        if (count($tmp) === 3) {
            $md_standard = $tmp[0];
            $node = $tmp[1];
            $profil_id = $tmp[2];
        }
        if (isset($post['btn']) && $post['btn'] == 'save') {
            //dump($this->context->getByType('Nette\Http\Request')->getPost());
            $report = $this->mdProfile->cloneProfil($md_standard, $profil_id, $post);
            if ($report != '') {
                $this->flashMessage($report);
            }
            //$this->terminate();
        }
        $this->redirect(':Admin:Profile:default', $md_standard.','.$node);    
    }

    /** @resource Admin */
    public function actionClone($id)
    {
        $this->template->id = $id;
        $this->setView('new');
    }

    /** @resource Admin */
    public function actionDelete($id)
    {
        $md_standard = NULL;
        $node = NULL;
        $profil = NULL;
        $tmp = explode(',', $id);
        if (count($tmp) === 3) {
            $md_standard = $tmp[0];
            $node = $tmp[1];
            $profil_id = $tmp[2];
        }
        $this->mdProfile->deleteProfil($md_standard, $profil_id);
        $this->redirect(':Admin:Profile:default', $md_standard.','.$node);    
    }
}
