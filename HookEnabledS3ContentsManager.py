from s3contents import S3ContentsManager

class HookEnabledS3ContentsManager(S3ContentsManager):
    def save(self, model, path):
        self.run_pre_save_hook(model=model, path=path)
        return super().save(model=model, path=path)
    
